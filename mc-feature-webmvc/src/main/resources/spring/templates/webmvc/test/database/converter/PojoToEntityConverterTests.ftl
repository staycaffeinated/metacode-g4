<#include "/common/Copyright.ftl">

package ${PojoToEntityConverter.packageName()};

import ${Entity.fqcn()};
import ${EntityResource.fqcn()};
import ${SecureRandomSeries.fqcn()};
import ${ResourceIdSupplier.fqcn()};
import ${EjbTestFixtures.fqcn()};
import ${ModelTestFixtures.fqcn()};

import org.assertj.core.util.Lists;
import org.junit.jupiter.api.Test;

import java.util.List;

import static org.assertj.core.api.Assertions.assertThat;
import static org.junit.jupiter.api.Assertions.assertThrows;

@SuppressWarnings("all")
class ${PojoToEntityConverter.testClass()} {

    ${PojoToEntityConverter.className()} converter = new ${PojoToEntityConverter.className()}();

    final ${ResourceIdSupplier.className()} randomSeries = new ${SecureRandomSeries.className()}();

    @Test
    void shouldReturnNullWhenResourceIsNull() {
        assertThrows (NullPointerException.class, () ->  { converter.convert((${endpoint.pojoName}) null); });
    }

    @Test
    void shouldReturnNullWhenListIsNull() {
        assertThrows (NullPointerException.class, () -> { converter.convert((List<${endpoint.pojoName}>)null); });
    }

    @Test
    void shouldPopulateAllFields() {
        ${EntityResource.className()} resource = ${ModelTestFixtures.className()}.oneWithResourceId();

        ${Entity.className()} bean = converter.convert(resource);
        assertThat(bean.getResourceId()).isEqualTo(resource.getResourceId());
        assertThat(bean.getText()).isEqualTo(resource.getText());
    }

    @Test
    void shouldCopyList() {
        var pojoList = ${ModelTestFixtures.className()}.allItems();

        List<${Entity.className()}> ejbList = converter.convert(pojoList);
        assertThat(ejbList.size()).isSameAs(pojoList.size());
        // spot check the first entry
        assertThat(ejbList.get(0).getResourceId()).isEqualTo(pojoList.get(0).getResourceId());
        assertThat(ejbList.get(0).getText()).isEqualTo(pojoList.get(0).getText());
    }


    @Test
    void shouldCopyUpdatedFields() {
        /* Give some POJO and EJB that represent the same entity */
        ${EntityResource.className()} pojo = ${ModelTestFixtures.className()}.oneWithResourceId();
        ${Entity.className()} bean = converter.convert(pojo);

        /* Change some fields of the POJO to mimic changes received from, say, an end user */
        pojo.setText("Some new value");

        /* To update the corresponding EJB, copy the mutable fields of the POJO to the EJB */
        /* (Immutable fields, like IDs, do not get updated.) */
        converter.copyUpdates(pojo, bean);

        /* Verify the mutable fields of the EJB were updated to match the POJO */
        assertThat(bean.getText()).isEqualTo(pojo.getText());
    }


    @Test
    void shouldThrowExceptionIfPojoIsNull() {
            ${Entity.className()} anyEjbWillDo = ${EjbTestFixtures.className()}.oneWithResourceId();
            assertThrows(NullPointerException.class,
                    () -> { converter.copyUpdates((${EntityResource.className()}) null, anyEjbWillDo); });
    }

    @Test
    void shouldThrowExceptionIfEjbIsNull() {
        ${EntityResource.className()} anyPojoWillDo = ${ModelTestFixtures.className()}.oneWithResourceId();
            assertThrows(NullPointerException.class,
            () -> { converter.copyUpdates(anyPojoWillDo, null); });
    }
}
